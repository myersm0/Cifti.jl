
function read_cifti(ciftifile::String; dtype = Float32)::Matrix{Float32}
	@assert isfile(ciftifile)
	fid = open(ciftifile, "r")
	temp = zeros(UInt8, nifti_hdr_size)
	readbytes!(fid, temp, nifti_hdr_size)
	hdr = reinterpret(Int32, temp)
	@assert(hdr[1] == nifti_hdr_size, "Input file doesn't follow cifti2 specs")
	nrows = Int64(hdr[15])
	ncols = Int64(hdr[17])
	vox_offset = hdr[43] # where does the data begin

	seek(fid, vox_offset)
	bytes_to_read = nrows * ncols * sizeof(dtype)
	data = zeros(UInt8, bytes_to_read)
	readbytes!(fid, data, bytes_to_read)
	close(fid)

	@chain data begin
		reinterpret(dtype, _)
		reshape(_, (nrows, ncols))
	end
end
export read_cifti

# helper for get_brainstructure()
function parse_verts_from_node(node::EzXML.Node)
	@chain node begin
		nodecontent
		strip 
		split 
		parse.(Int, _)
	end
end

function get_brainstructure(filename::String)::Vector{CiftiStruct}
	fid = open(filename, "r")
	hdr = zeros(UInt8, nifti_hdr_size)
	readbytes!(fid, hdr, nifti_hdr_size)

	# most of the below vars will not be needed; this is just to demo
	# how they may be extracted from the hdr, if we ever want to do so
	sizeof_hdr = reinterpret(Int32, hdr[1:4])[1]
	data_type = reinterpret(Int16, hdr[13:14])[1]
	bitpix = reinterpret(Int16, hdr[15:16])[1]
	dim = reinterpret(Int64, hdr[17:80])
	vox_offset = reinterpret(Int64, hdr[169:176])[1]
	intent_code = reinterpret(Int32, hdr[505:508])[1]
	intent_name = 
		@chain begin
			hdr[509:(509 + 15)]
			Char.(_)
			filter(x -> x != '\0', _)
			join
		end
	dim_info = Char(hdr[525])
	nrows = dim[7]
	ncols = dim[6]

	# parse xml from raw bytes that follow the hdr
	seek(fid, nifti_hdr_size)
	temp = zeros(UInt8, vox_offset - nifti_hdr_size)
	readbytes!(fid, temp, vox_offset - nifti_hdr_size)
	filter!(x -> x != 0, temp)
	start_at = 1 + findfirst(temp .== 0x0a) # xml begins after 1st newline
	docroot = 
		@chain begin
			temp[start_at:end]
			Char.(_)
			join
			parsexml
			root
		end

	brainmodel_nodes = findall("//BrainModel", docroot)
	brainstructure = Vector{CiftiStruct}()
	for node in brainmodel_nodes
		verts = parse_verts_from_node(node)
		index_offset = parse(Int, node["IndexOffset"])
		index_count = parse(Int, node["IndexCount"])
		@assert index_offset == length(brainstructure)
		struct_name = 
			@chain begin
				node["BrainStructure"]
				replace(_, r"CIFTI_STRUCTURE_" => "")
				Meta.parse
				eval
			end
		append!(brainstructure, fill(struct_name, index_count))
	end
	close(fid)
	brainstructure
end
export get_brainstructure


