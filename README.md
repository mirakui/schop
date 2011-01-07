# Schop

A ruby cli wrapper to make ssh direct port forwarding.
This gem is based on 'tunnel'.

## Usage

    schop start        # Start a schop daemon and ssh processes
    schop stop         # Stop the schop daemon and ssh processes
    schop status       # Show process statuses

## Config

Please put ~/.schop as a yaml file before run schop.
For example:

    ---
    gateways:
      my_gateway_name1:
        gateway_host: xxx.xxx.xxx.xxx
        ssh_port: 22
        gateway_user: mirakui
        dynamic_port: 1080
        local_ports:
          - 13306:127.0.0.1:3306
          - 10025:127.0.0.1:25
      my_gateway_name2:
        :
        :

Then schop will run following ssh command:

    ssh -p 22 -D 1080 -L 13306:127.0.0.1:3306 -L 10025:127.0.0.1:25 mirakui@xxx.xxx.xxx.xxx
