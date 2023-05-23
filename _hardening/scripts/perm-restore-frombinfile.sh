if [ ! $1 ]; then
    echo "Usage: ./perm-restore-frombinfile.sh /var/log/permissions/bin_..."
    exit 1
fi

if [[ ! $1 == /var/log/permissions/bin_* ]]; then
    echo "Input file path error."
    echo "A valid input file path is: /var/log/permissions/bin_"
    exit 1
fi

while IFS=" " read _perm _path; do
    chmod $_perm $_path
done < $1
