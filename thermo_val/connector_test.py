import unittest

import utils
import connector 

class TestRMGTestsDatabaseInterface(unittest.TestCase):
    """
    Contains unit tests for methods of RMGTestsDatabaseInterface
    """

    def testConnectFailure(self):

        host = 'somehost'
        port = 27017
        username = 'me'
        password = 'pswd'

        tcdi = connector.RMGTestsDatabaseInterface(host, port, username, password)

        self.assertTrue(tcdi.client is None)

    def testConnectSuccess(self):

        auth_info = utils.get_RTD_authentication_info()

        tcdi = connector.RMGTestsDatabaseInterface(*auth_info)

        self.assertTrue(tcdi.client is not None)