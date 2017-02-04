# openvas_pg
A Docker container for the Openvas that use PostgreSQL as db

| Openvas Version | Tag         | Ports                     |
|-----------------|-------------|---------------------------|
| 9               | latest/9.0.0| gsad->4000, postgres->7432|


Usage
-----

Run:

```
docker-compose up
```

Greenbone: `https://<machinename>:4000`

```
Username: sadmin
Password: changeme
```

To check the status of the process, run:

```
docker top openvas
```

To run bash inside the container run:

```
docker exec -it openvas_pg_container bin/bash
```

OpenVAS
-------
OpenVAS is a framework of several services and tools offering a comprehensive and powerful vulnerability scanning and vulnerability management solution.
http://www.openvas.org

- [Install OpenVAS from Source Code](http://www.openvas.org/install-source.html)
- [API DOC: OpenVAS Management Protocol (OMP) Version 7.0](http://docs.greenbone.net/API/OMP/omp-7.0.html)

Thanks
------
Thanks to Mike Splain (mikesplain) for the great work on openvas-docker: https://github.com/mikesplain/openvas-docker
and to William Collani for the article [Docker-based OpenVAS Scanning Cluster to Improve Scope Scalability](https://www.nopsec.com/blog/docker-based-openvas-scanning-cluster-improve-scope-scalability/)
