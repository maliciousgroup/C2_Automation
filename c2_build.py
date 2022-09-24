from python_terraform import Terraform, IsFlagged
from yaml import safe_load, YAMLError


def build(template: str, token: str, domain: str) -> dict:
    tf = Terraform(working_dir=template)
    ret, stdout, stderr = tf.apply(
        capture_output=True,
        no_color=IsFlagged,
        skip_plan=True,
        var={'linode_token': token, 'linode_domain': domain})
    if stdout:
        return tf.output()
    if stderr:
        print(stderr)
    return {}


def destroy(template: str, token: str, domain: str) -> None:
    tf = Terraform(working_dir=template)
    ret, stdout, stderr = tf.destroy(
        capture_output=True,
        auto_approve=True,
        force=None,
        var={'linode_token': token, 'linode_domain': domain})
    if stdout:
        print("[*] C2 Build destruction complete!\n")
    if stderr:
        print(stderr)


if __name__ == "__main__":
    import os

    _token: str = ""
    _domain: str = ""
    _template: str = "src/templates"

    if os.name == 'nt':
        print("[!] This tool requires the Linux operating system. Exiting.\n")
        exit(1)

    print("[*] Pulling configuration from src/config/network.yaml")

    try:
        with open('src/config/network.yaml', 'r') as file:
            data = safe_load(file)
            _token = data['linode']['token']
            _domain = data['linode']['domain']
    except (OSError, YAMLError):
        print("[!] Error parsing the YAML configuration file.\n")
        exit(1)

    print("[*] Building network...")
    output: dict = build(_template, _token, _domain)

    print("[*] Output from build...")
    for x in output:
        print(f"Instance {x} has IP {output[x]['value']}")
    input("\nPress any key to destroy build...")
    print("[*] Destroying network...")
    destroy(_template, _token, _domain)
