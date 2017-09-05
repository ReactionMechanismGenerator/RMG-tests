import os
import ConfigParser

def read_config(cfg_path='default'):
	'''This function reads a configuration file and returns an equivalent dictionary'''

	config_parser = ConfigParser.SafeConfigParser()
	config_parser.optionxform = str

	if cfg_path == 'default':
		cfg_path = os.path.join(os.path.dirname(__file__), 'config.cfg')
	with open(cfg_path, 'r') as fid:
		config_parser.readfp(fid)
	return config_parser._sections

def get_RTD_authentication_info(cfg_path='default'):
	
	try:
		config = read_config(cfg_path)

		host = config['RMGTESTSDATABASE']['RTD_HOST']
		port = int(config['RMGTESTSDATABASE']['RTD_PORT'])
		username = config['RMGTESTSDATABASE']['RTD_USER']
		password = config['RMGTESTSDATABASE']['RTD_PW']

		return host, port, username, password
	except KeyError:
		print('RMG-tests Database Configuration File  Not Completely Set!')
 
	return 'None', 0, 'None', 'None'

def get_testing_RTD_authentication_info():

    try:
        host = os.environ['RTD_HOST']
        port = int(os.environ['RTD_PORT'])
        username = os.environ['RTD_USER']
        password = os.environ['RTD_PW']
    except KeyError:
        print('RMG-tests Database Authentication Environment Variables Not Completely Set!')
        return 'None', 0, 'None', 'None'

    return host, port, username, password