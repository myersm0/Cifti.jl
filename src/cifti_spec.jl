
# from discourse.julialang.org/t/export-enum/5396
macro exported_enum(name, args...)
	esc(quote
		@enum($name, $(args...))
		export $name
		$([:(export $arg) for arg in args]...)
		end)
	end
export exported_enum

@exported_enum(CiftiStruct,
	CORTEX_LEFT, CORTEX_RIGHT,
	ACCUMBENS_LEFT, ACCUMBENS_RIGHT,
	AMYGDALA_LEFT, AMYGDALA_RIGHT,
	BRAIN_STEM,
	CAUDATE_LEFT, CAUDATE_RIGHT,
	CEREBELLUM_LEFT, CEREBELLUM_RIGHT,
	HIPPOCAMPUS_LEFT, HIPPOCAMPUS_RIGHT,
	PALLIDUM_LEFT, PALLIDUM_RIGHT,
	PUTAMEN_LEFT, PUTAMEN_RIGHT,
	THALAMUS_LEFT, THALAMUS_RIGHT,
	# in my experience, structures in cifti files are limited to the above;
	# but the specification lists the following additional possible values,
	# so listing these for completeness:
	CORTEX,
	CEREBELLUM,
	CEREBELLAR_WHITE_MATTER_LEFT, CEREBELLAR_WHITE_MATTER_RIGHT,
	OTHER_WHITE_MATTER, OTHER_GREY_MATTER,
	ALL_WHITE_MATTER, ALL_GREY_MATTER,
	OTHER
)
export CiftiStruct

const nifti_hdr_size = 540

