default:
    echo 'Hello, world!'

init:
    mkdir -p secrets
    # pg secrets
    touch secrets/STORAGE_PASSWORD
    

[confirm("this will remove all setted up secrets! Type 'y' to confirm.")]
reset:
    rm -rf secrets