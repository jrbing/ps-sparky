#!/usr/bin/env python
# vim: filetype=python tabstop=8 expandtab shiftwidth=4 softtabstop=4
# -*- coding: utf-8 -*-

import sys
import imp
import os
scriptpath = os.path.dirname(sys.argv[0])
pswls = imp.load_source('pswls', scriptpath + '/pswls.py')


def main():
    # Get the file variables from the arguments passed to the script
    config_file = sys.argv[1]
    key_file = sys.argv[2]
    connection_url = sys.argv[3]

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    # Change to the correct Mbean
    serverRuntime()

    # Get status and health
    cd('/')
    server_health_state = cmo.getHealthState()
    server_status = cmo.getState()

    # Get JVM statistics
    cd('/JVMRuntime/PIA')
    heap_size = int((cmo.getHeapSizeCurrent()/1024)/1024)
    free_heap = int((cmo.getHeapFreeCurrent()/1024)/1024)
    free_heap_percent = cmo.getHeapFreePercent()

    # Get application session statistics
    cd('/ApplicationRuntimes/peoplesoft/ComponentRuntimes/PIA_')
    open_sessions = cmo.getOpenSessionsCurrentCount()
    max_sessions = cmo.getOpenSessionsHighCount()

    # Get threadpool statistics
    cd('/ThreadPoolRuntime/ThreadPoolRuntime')
    execute_thread_idle_count = cmo.getExecuteThreadIdleCount()
    execute_thread_total_count = cmo.getExecuteThreadTotalCount()
    hogging_thread_count = cmo.getHoggingThreadCount()
    standby_thread_count = cmo.getStandbyThreadCount()
    pending_user_request_count = cmo.getPendingUserRequestCount()
    queue_length = cmo.getQueueLength()
    throughput = cmo.getThroughput()

    print '***************************************************'
    print 'Server Health State: ', server_health_state
    print 'Server Status: ', server_status
    print '***************************************************'
    print 'Heap Size: ', heap_size
    print 'Free Heap: ', free_heap
    print 'Free Heap %: ', free_heap_percent
    print '***************************************************'
    print 'Open Sessions: ', open_sessions
    print 'Session High-Water Mark: ', max_sessions
    print '***************************************************'
    print 'Execute Thread Idle Count: ', execute_thread_idle_count
    print 'Execute Thread Total Count: ', execute_thread_total_count
    print 'Hogging Thread Count: ', hogging_thread_count
    print 'Standby Thread Count: ', standby_thread_count
    print 'Pending User Request Count: ', pending_user_request_count
    print 'Queue Length: ', queue_length
    print 'Throughput: ', throughput
    print '***************************************************'


main()

