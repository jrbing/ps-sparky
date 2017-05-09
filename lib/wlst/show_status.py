#!/usr/bin/env python
# vim: filetype=python tabstop=8 expandtab shiftwidth=4 softtabstop=4
# -*- coding: utf-8 -*-

import sys
import imp
import os
scriptpath = os.path.dirname(sys.argv[0])
pswls = imp.load_source('pswls', scriptpath + '/lib/pswls.py')

def get_jvm_statistics():
    cd('/JVMRuntime/PIA')
    totaljvm = int((cmo.getHeapSizeCurrent()/(1024*1024)))
    freejvm = int((cmo.getHeapFreeCurrent()/(1024*1024)))
    usedjvm = (totaljvm - freejvm)
    pswls.print_double_hl()
    print 'JVM Size: %4d MB' % (totaljvm)
    print 'Used JVM: %4d MB' % (usedjvm)
    print 'Free JVM: %4d MB' % (freejvm)
    pswls.print_double_hl()
    print ''
    pass


def get_health_status():
    cd('/')
    server_health_state = cmo.getHealthState()
    server_status = cmo.getState()
    pswls.print_double_hl()
    print 'Server Health: %s' % (server_health_state)
    print 'Server Status: ', server_status
    pswls.print_double_hl()
    print ''
    pass

def get_application_session_statistics():
    cd('/ApplicationRuntimes/peoplesoft/ComponentRuntimes/PIA_')
    open_sessions = cmo.getOpenSessionsCurrentCount()
    max_sessions = cmo.getOpenSessionsHighCount()
    pswls.print_double_hl()
    print 'Open Sessions: ', open_sessions
    print 'Session High-Water Mark: ', max_sessions
    pswls.print_double_hl()
    print ''
    pass

def get_threadpool_statistics():
    cd('/ThreadPoolRuntime/ThreadPoolRuntime')
    execute_thread_idle_count = cmo.getExecuteThreadIdleCount()
    execute_thread_total_count = cmo.getExecuteThreadTotalCount()
    hogging_thread_count = cmo.getHoggingThreadCount()
    standby_thread_count = cmo.getStandbyThreadCount()
    pending_user_request_count = cmo.getPendingUserRequestCount()
    queue_length = cmo.getQueueLength()
    throughput = cmo.getThroughput()
    pswls.print_double_hl()
    print 'Execute Thread Idle Count: ', execute_thread_idle_count
    print 'Execute Thread Total Count: ', execute_thread_total_count
    print 'Hogging Thread Count: ', hogging_thread_count
    print 'Standby Thread Count: ', standby_thread_count
    print 'Pending User Request Count: ', pending_user_request_count
    print 'Queue Length: ', queue_length
    print 'Throughput: ', throughput
    pswls.print_double_hl()
    print ''
    pass

def main():
    # Get the file variables from the arguments passed to the script
    config_file = sys.argv[1]
    key_file = sys.argv[2]
    connection_url = sys.argv[3]

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    # Change to ServerRuntime
    serverRuntime()

    get_jvm_statistics()
    get_health_status()
    get_application_session_statistics()
    get_threadpool_statistics()


main()
