# Sample script to install additional dependencies
# At the moment, we need nothing

### Handling different OSes
if [ -f /etc/redhat-release ]; then
    # Do Nothing
    :
fi
if [ -f /etc/lsb-release ]; then
    # Do Nothing
    :
fi