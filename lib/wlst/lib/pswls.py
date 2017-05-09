

def print_error(message):
    print '\033[1;31m * ERROR\033[0m: ' + message


def print_info(message):
    print '\033[1;32m * INFO\033[0m: ' + message


def print_warn(message):
    print '\033[1;33m * WARN\033[0m: ' + message


def print_hl():
    print '\033[1;33m----------------------------------------\033[0m'


def print_double_hl():
    print '\033[1;33m========================================\033[0m'


def get_username():
    default = "system"
    username = raw_input('Weblogic Admin Username [default=system]: ')
    if not username:
        username = default
    return username


def get_password():
    default = "Passw0rd"
    password = raw_input("Weblogic Admin Password [default=Passw0rd]: ")
    if not password:
        password = default
    return password
