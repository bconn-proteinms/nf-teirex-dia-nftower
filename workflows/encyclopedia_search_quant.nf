// Modules
include { MSCONVERT } from "../modules/msconvert"

workflow encyclopeda_search_quant {

    take:
        spectra_file_ch
        fasta
        spectral_library
        from_raw_files
        do_domultiplex
    
    main:

        // convert raw files to mzML files if necessary
        if(from_raw_files) {
            mzml_file_ch = MSCONVERT(spectra_file_ch, do_domultiplex)
        } else {
            mzml_file_ch = spectra_file_ch
        }


}
