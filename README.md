# DWHP

[Docker-WireGuard](https://github.com/JustABeginning/Docker-WireGuard) with Proxy on Host

# Usage

- Ingredients
  - Linux

    ```console

    foo@bar:~$ source envsetup.sh

    ```

  - Windows

    ```console

    foo@bar:~$ envsetup.bat

    ```

- Just, fire it up !

  ```console

  foo@bar:~$ docker compose up -d

  ```

- Or, put it down ...

  ```console

  foo@bar:~$ docker compose down

  ```

# Features

- Client configuration is auto-generated, and placed in the `storage/` directory of `pwd`

- Wire your container with the Proxy on your Host

  ```console

  foo@bar:~$ ssh -p 2224 -R 8080:<PROXY_IP>:<PROXY_PORT> <SSH_USER>@localhost

  ```

# References

- [Intercepting AWS Traffic Through BurpSuite in Isolated and Serverless Environments](https://medium.com/@asif.iqbal.gazi/intercepting-aws-traffic-through-burpsuite-in-isolated-and-serverless-environments-61d3635b0ba8)

- [How to Configure GatewayPorts in sshd_config for IPv4 Remote Forwarding](https://oneuptime.com/blog/post/2026-03-20-ssh-gatewayports-ipv4-remote-forwarding/view)

- [The IPv6 situation on Docker is good now!](https://ounapuu.ee/posts/2024/12/20/docker-ipv6/)
