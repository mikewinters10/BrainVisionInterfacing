# -*- coding: utf-8 -*-
'''
Tutorial Data Channeling

PyCorder ActiChamp Recorder

------------------------------------------------------------

Copyright (C) 2010, Brain Products GmbH, Gilching

This file is part of PyCorder

PyCorder is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PyCorder. If not, see <http://www.gnu.org/licenses/>.

------------------------------------------------------------

@author: R. Michael Winters
@date: $Date: 2015-11-10 14:29:17 $
@version: 1.0

B{Revision:} $LastChangedRevision: 62 $
'''

from modbase import *

class printChannelData(ModuleBase):
    ''' Tutorial on working with Data from channels
        Copied from tut_1.py
    
    Command and event handling. 
        - 
    '''

    def __init__(self, *args, **keys):
        ''' Constructor
        '''
        # initialize the base class, give a descriptive name
        ModuleBase.__init__(self, name="Tutorial 0", **keys)    

        # initialize module variables
        self.data = None                # hold the data block we got from previous module
        self.dataavailable = False      # data available for output to next module 
        
        
    def process_input(self, datablock):
        ''' Get data from previous module
        @param datablock: EEG_DataBlock object 
        '''
        self.dataavailable = True       # signal data availability
        self.data = datablock           # get a local reference
        
        # Using the EEG_DataBlock p. 58 of user manual. Send Channel 5 and the timestamp.
        # print self.data.eeg_channels[5]
        # print self.data.block_time
        
        test = "13"
        
        # Sending UDP
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(test,("127.0.0.1",5005))
        
        
        # Receiving UDP
        # sock.bind(("127.0.0.1", 5005))
        # while True:
        #    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
        #   print "received message:", data
    
    def process_output(self):
        ''' Send data out to next module
        '''
        if not self.dataavailable:
            return None
        self.dataavailable = False
        return self.data
    

