
def print_error(message):
    print '\033[1;31m * ERROR\033[0m: ' + message


def print_info(message):
    print '\033[1;32m * INFO\033[0m: ' + message


def print_warn(message):
    print '\033[1;33m * WARN\033[0m: ' + message


def print_hl():
    print '\033[1;33m----------------------------------------\033[0m'


def get_username():
    """
    Prompt for the weblogic console username and return the value
    """
    default = "system"
    # username = raw_input("Weblogic Admin Username: %s"%default + chr(8)*6)
    username = raw_input('Weblogic Admin Username [default=system]: ')
    if not username:
        username = default
    return username


def get_password():
    """
    Prompt for the weblogic console user password and return the value
    """
    default = "Passw0rd"
    password = raw_input("Weblogic Admin Password [default=Passw0rd]: ")
    if not password:
        password = default
    return password


def connect_admin(config_file, key_file, url):
    return_code = 1
    try:
        connect(userConfigFile=config_file,
                userKeyFile=key_file,
                url=connection_url)
        print "*** Connected sucessesfully ***"
        return_code = 0
        sys.exit(r)
    except:
        return return_code


# This module is for retrieve the JVM statistics
def monitorJVMHeapSize():
    connect(userConfigFile=ucf, userKeyFile=ukf, url=admurl)
    serverNames = getRunningServerNames()
    domainRuntime()

    print '                TotalJVM  FreeJVM  Used JVM'
    print '=============================================='
    for name in serverNames:
        try:
            cd("/ServerRuntimes/"+name.getName()+"/JVMRuntime/"+name.getName())
            freejvm = int(get('HeapFreeCurrent'))/(1024*1024)
            totaljvm = int(get('HeapSizeCurrent'))/(1024*1024)
            usedjvm = (totaljvm - freejvm)
            print '%14s  %4d MB   %4d MB   %4d MB ' %  (name.getName(),totaljvm, freejvm, usedjvm)
        except WLSTException,e:
            pass


def get_running_server_names():
     domainConfig()
     return cmo.getServers()


def example_main():
    connect(ADMINUSER, ADMINPASSWD, ADMINURL)

    print "Before machines creation..."
    printMachineList()

    edit()
    startEdit()

    for i in range(1, 5):
        try:
            createMachine(
                'machine' + str(i), '192.168.33.' + str(100 + i), 5566)
        except:
            print 'Machine creation failed...' + 'machine' + str(i)
    activate()

    print "After creation..."
    printMachineList()

    HitKey = raw_input('Press any key to continue...')

    startEdit()
    for i in range(1, 5):
        try:
            deleteMachine('machine' + str(i))
        except:
            print 'Unable to remove machine...'
    activate()

    print "After removing machines..."
    printMachineList()

#=======================================================
# This script will monitor the JDBC CONNECTION POOL
# Date :  18 Apr 2012
#=======================================================

# def another_example():
    # try:
        # loadProperties('./DBcheck.properties')
        # fp=open('ActiveConn.log','a+')
        # Date = time.ctime(time.time())
        # admurl='t3://'+admAdrs+':'+admPort
        # connect(userConfigFile=UCF, userKeyFile=UKEY, url=admurl)
        # poolrtlist=adminHome.getMBeansByType('JDBCConnectionPoolRuntime')
        # print ' '
        # print 'JDBC CONNECTION POOLS'
        # print>>fp, '================================================ '

        # for poolRT in poolrtlist:
            # pname = poolRT.getName()
            # pmaxcapacity = poolRT.getAttribute("MaxCapacity")
            # paccc = poolRT.getAttribute("ActiveConnectionsCurrentCount")

            # if pname == 'myDataSource1' or pname == 'myDS2'' or pname == 'myDS3':
                # server= str(poolRT).split(',')[2].split('=')[1]
                # p=(paccc /(pmaxcapacity * 1.0)) * 100
                # if p >= 85:
                    # print >>fp, 'WARNING: The Active connections are Greater than Threshold 85%'
                    # print>>fp, '%24s %15s %18s %7d %7d' % (Date,server,pname,pmaxcapacity,paccc)

    # except:
        # sys.stderr.write('ERROR: %s\n' % str(e))
        # print 'Error:', e
        # dumpStack()
        # pass
