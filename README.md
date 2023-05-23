# Cifti

This package supplies a basic function `read_cifti` for reading files of the CIFTI-2 format (https://www.nitrc.org/projects/cifti) for fMRI data. It's great if you just want to quickly read in some data from such filetypes for analysis or visualization, and because of its simplicity it's very fast. However, for more complex use cases in Julia, I recommend instead using Julia's cross-language interoperability to take advantage of one of several more robust and comprehensive implementations (see the `cifti` and `ciftiTools` R packages, `nibabel` in Python, etc).

While the variety of possible CIFTI files allowed by the specification is quite large, in this author's experience only a very narrow subset of them are to be found in practice. Provided that this holds true for you, the `read_cifti()` function supplied here should work fine for any of the major CIFTI filetypes (dtseries, dscalar, ptseries, dconn, etc). Some care is required on the user's part, however, in verifying that the data loads into a format that matches his or her expectations. For example, dtseries files in this package should load with timepoints represented along the rows and spatial elements along the columns, contrary to the orientation one may expect from some other implementations.

The basic usage is demonstrated below. A `CiftiObj` struct is returned, containing a rudimentary header `hdr`, a data component `data` (simply a numeric matrix of whatever data type is specified in the cifti file header), and a `brainstructure` component (an ordered dictionary of indices into anatomical structures as parsed from the CIFTI file's internal XML data).

```
x = read_cifti("my_cifti_file.dtseries.nii")
x.data # access the data matrix
x.brainstructure # access the dictionary of anatomical indices
```

Several pacakges are currently under development to complement this one, including one for 3D visualization of cifti objects (with GLMakie), and a collection of high performance algorithms for operating on CIFTI data.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://myersm0.github.io/Cifti.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://myersm0.github.io/Cifti.jl/dev/)
[![Build Status](https://github.com/myersm0/Cifti.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/Cifti.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/myersm0/Cifti.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/myersm0/Cifti.jl)
