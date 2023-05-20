
struct CiftiObj
	data::Matrix
	brainstructure::Dict{CiftiStructure, UnitRange}
end

function Base.getindex(cifti::CiftiObj, s::CiftiStructure)
	inds = cifti.brainstructure[s]
	cifti.data[:, inds]
end

function Base.getindex(cifti::CiftiObj, s::Vector{CiftiStructure})
	inds = union([cifti.brainstructure[x] for x in s]...)
	cifti.data[:, inds]
end

# specifically the below assumes we'll deal with headers of the NIfTI-2 spec;
# there are many more fields available, but this is sufficient for basic use
struct NiftiHeader
	dtype::DataType
	nrows::Int64
	ncols::Int64
	vox_offset::Int64
end

function get_nifti2_hdr(fid::IOStream)::NiftiHeader
	seek(fid, 0)
	bytes = zeros(UInt8, nifti_hdr_size)
	readbytes!(fid, bytes, nifti_hdr_size)
	dtype = dtypes[reinterpret(Int16, bytes[13:14])[1]]
	dims = reinterpret(Int64, bytes[17:80])
	nrows = dims[6]
	ncols = dims[7]
	vox_offset = reinterpret(Int64, bytes[169:176])[1]
	NiftiHeader(dtype, nrows, ncols, vox_offset)
end

function get_cifti_data(fid::IOStream, hdr::NiftiHeader)
	seek(fid, hdr.vox_offset)
	bytes_to_read = hdr.nrows * hdr.ncols * sizeof(hdr.dtype)
	data = zeros(UInt8, bytes_to_read)
	readbytes!(fid, data, bytes_to_read)
	@chain data reinterpret(hdr.dtype, _) reshape(_, (hdr.nrows, hdr.ncols))
end

function extract_xml(fid::IOStream, hdr::NiftiHeader)::EzXML.Node
	# parse xml from raw bytes that follow the hdr
	seek(fid, nifti_hdr_size)
	bytes = zeros(UInt8, hdr.vox_offset - nifti_hdr_size)
	readbytes!(fid, bytes, hdr.vox_offset - nifti_hdr_size)
	filter!(.!iszero, bytes) # the below will error if we don't remove null bytes
	start_at = 1 + findfirst(bytes .== UInt8('\n')) # xml begins after 1st newline
	@chain begin
		bytes[start_at:end] 
		Char.(_) 
		join 
		parsexml 
		root
	end
end

function parse_brainmodel(docroot::EzXML.Node)::Dict{CiftiStructure, UnitRange}
	brainmodel_nodes = findall("//BrainModel", docroot)
	brainstructure = Dict{CiftiStructure, UnitRange}()
	for node in brainmodel_nodes
#		verts = @chain node nodecontent strip split parse.(Int, _)
		index_offset = parse(Int, node["IndexOffset"])
		index_count = parse(Int, node["IndexCount"])
		struct_name = 
			@chain begin
				node["BrainStructure"]
				replace(_, r"CIFTI_STRUCTURE_" => "")
				Meta.parse
				eval
			end
		start = index_offset + 1
		stop = start + index_count - 1
		brainstructure[struct_name] = start:stop
	end
	brainstructure
end

function read_cifti(filename::String)::CiftiObj
	@assert(isfile(filename), "$filename doesn't exist")
	open(filename, "r") do fid
		hdr = get_nifti2_hdr(fid)
		data = get_cifti_data(fid, hdr)
		brainstructure = extract_xml(fid, hdr) |> parse_brainmodel
		return CiftiObj(data, brainstructure)
	end
end
export read_cifti




