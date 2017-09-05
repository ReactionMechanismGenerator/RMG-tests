
import utils

class RMGTestsDatabaseInterface(object):
    """
    A class for interfacing with RMG-tests database.
    """

    def __init__(self, host, port, username, password):
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.client = self.connect()

    def connect(self):
        
        import pymongo

        remote_address = 'mongodb://{0}:{1}@{2}/rmg_tests'.format(self.username, 
                                                            self.password,
                                                            self.host)
        client = pymongo.MongoClient(remote_address, 
                                    self.port, 
                                    serverSelectionTimeoutMS=2000)
        try:
            client.server_info()
            print("\nConnection success to RMG-tests Database!\n")
            return client
        
        except (pymongo.errors.ServerSelectionTimeoutError,
                pymongo.errors.OperationFailure):
            print("\nConnection failure to RMG-tests Database...")
            return None
