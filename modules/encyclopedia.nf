def exec_java_command(mem) {
    def xmx = "-Xmx${mem.toGiga()-1}G"
    return "java -Djava.aws.headless=true ${xmx} -jar /usr/local/bin/encyclopedia.jar"
}

process ENCYCLOPEDIA_SEARCH_FILE {
    publishDir "${params.result_dir}/encyclopedia/search-file", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'quay.io/protio/encyclopedia:2.12.30'

    input:
        path mzml_file
        path fasta
        path spectra_library_file
        val encyclopedia_params

    output:
        path("*.stderr"), emit: stderr
        path("*.stdout"), emit: stdout
        path("${mzml_file}.elib", emit: elib)
        path("${mzml_file.baseName}.dia",  emit: dia)
        path("${mzml_file}.features.txt", emit: features)
        path("${mzml_file}.encyclopedia.txt", emit: results_targets)
        path("${mzml_file}.encyclopedia.decoy.txt", emit: results_decoys)
        

    script:
    """
    ${exec_java_command(task.memory)} \\
        -numberOfThreadsUsed ${task.cpus} \\
        -i ${mzml_file} \\
        -f ${fasta} \\
        -l ${spectra_library_file} \\
        -percolatorVersion /usr/local/bin/percolator \\
        ${encyclopedia_params} \\
        1>"encyclopedia-${mzml_file.baseName}.stdout" 2>"encyclopedia-${mzml_file.baseName}.stderr"
    """
}

process ENCYCLOPEDIA_CREATE_ELIB {
    publishDir "${params.result_dir}/encyclopedia/create-elib", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'quay.io/protio/encyclopedia:2.12.30'

    input:
        path mzml_files
        path search_elib_files
        path search_dia_files
        path search_feature_files
        path search_encyclopedia_targets
        path search_encyclopedia_decoys
        path fasta
        path spectra_library_file
        val align
        val outputFilePrefix
        val encyclopedia_params

    output:
        path("*.stderr"), emit: stderr
        path("*.stdout"), emit: stdout
        path("${outputFilePrefix}-combined-results.elib", emit: elib)

    script:
    """
    ${exec_java_command(task.memory)} \\
        -numberOfThreadsUsed ${task.cpus} \\
        -libexport \\
        -o '${outputFilePrefix}-combined-results.elib' \\
        -i ./ \\
        -a ${align} \\
        -f ${fasta} \\
        -l ${spectra_library_file} \\
        -percolatorVersion /usr/local/bin/percolator \\
        ${encyclopedia_params} \\
        1>"encyclopedia-create-elib.stdout" 2>"encyclopedia-create-elib.stderr"
    """
}
