
function read_parcels(filename::String)::Vector{UInt16}
	convert.(UInt16, read_cifti(filename)[:])
end
export read_parcels

function get_parcel_verts(
		parcels::Vector{UInt16}; baddata::BitVector = [], minsize::Int = 0
	)
	parc_ids = setdiff(parcels, 0)
	parcel_verts = [setdiff(findall(parcels .== parc), findall(baddata)) for parc in parc_ids]
	minsize > 0 || return parcel_verts
	vert_counts = [length(x) for x in parcel_verts]
	keep = findall(vert_counts .>= minsize)
	parc_ids = parc_ids[keep]
	[findall(parcels .== parc) for parc in parc_ids]
end
export get_parcel_verts

function get_parcel_centroid(verts::Vector{Int}, dmat::Matrix)::Int
	dists = mapslices(sum, dmat[verts, verts]; dims = 1)[:]
	winner = argmin(dists)
	verts[winner]
end
export get_parcel_centroid

function get_parcel_centroid(parcels::Vector{UInt16}, parc::Number, dmat::Matrix)::Int
	verts = findall(parcels .== parc)
	get_parcel_centroid(verts, dmat)
end
export get_parcel_centroid





