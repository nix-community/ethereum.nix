{
  systems = [ "x86_64-linux" ];
  module =
    { pkgs, ... }:
    let
      relay = pkgs.writeText "test-relay.py" ''
        from http.server import BaseHTTPRequestHandler, HTTPServer
        class Relay(BaseHTTPRequestHandler):
            def do_GET(self):
                self.send_response(200 if self.path == "/eth/v1/builder/status" else 404)
                self.end_headers()
        HTTPServer(("127.0.0.1", 28550), Relay).serve_forever()
      '';
    in
    {
      name = "mev-boost";
      nodes.machine = {
        virtualisation.memorySize = 2048;
        environment.systemPackages = [ pkgs.curl ];
        systemd.services.test-relay = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.ExecStart = "${pkgs.python3}/bin/python ${relay}";
        };
        services.ethereum.mev-boost.test = {
          enable = true;
          settings = {
            addr = "127.0.0.1:18550";
            sepolia = true;
            relay-check = true;
            relays = [
              "http://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@127.0.0.1:28550"
            ];
          };
        };
        systemd.services.mev-boost-test.after = [ "test-relay.service" ];
      };
      testScript = ''
        start_all()
        machine.wait_for_unit("test-relay.service")
        machine.wait_for_unit("mev-boost-test.service")
        machine.wait_for_open_port(18550)
        machine.wait_until_succeeds("curl -fsS http://127.0.0.1:18550/eth/v1/builder/status")
        machine.succeed("test $(systemctl show mev-boost-test.service -p NRestarts --value) = 0")
        machine.succeed("systemctl show mev-boost-test.service -p DynamicUser --value | grep -x yes")
      '';
    };
}
