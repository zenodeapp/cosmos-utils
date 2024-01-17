ROOT=$(cd "$(dirname "$0")"/ && pwd)

# Count the number of items in the folder
item_count=$(ls -A "$ROOT" | wc -l)

# Check if there is exactly one item in the folder (your script)
if [ "$item_count" -ne 1 ]; then
    echo "Error: The folder should only contain the installer.sh file. Please remove any additional files."
    exit 1
fi

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --version)
            shift
            if [ $# -gt 0 ]; then
                VERSION="$1"
            else
                echo "Error: --version option requires a value."
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

if [ -z "$VERSION" ]; then
    VERSION=main
fi

echo "This will download the updater.sh file from the $VERSION branch/tag/commit of the cosmos-utils repository and run it (change this using \e[3m--version [tag|commit|branch]\e[0m)."
echo ""
read -p "Do you want to continue? (Y/n): " ANSWER

ANSWER=$(echo "$ANSWER" | tr 'A-Z' 'a-z')  # Convert to lowercase

if [ "$ANSWER" = "n" ]; then
    echo "Aborted."
    exit 1
fi

UPDATER=".install/updater.sh"
REPO="https://raw.githubusercontent.com/zenodeapp/cosmos-utils/$VERSION"
mkdir -p "$(dirname "$ROOT/$UPDATER")"
wget --no-cache -q "$REPO/$UPDATER" -O "$ROOT/$UPDATER"

echo ""
sh $ROOT/$UPDATER --version "$VERSION" --reset
rm -f $ROOT/installer.sh
