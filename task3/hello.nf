process HELLO {
    output:
    stdout

    script:
    """
    echo "Hello World"
    """
}

workflow {
    HELLO()
}
