<?php

return [
    'db' => [
        'driver' => 'oci8',
        'connection_string' => '(DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = 10.255.0.103)(PORT = 1521))
        (CONNECT_DATA =
        (SERVER = DEDICATED)
        (SERVICE_NAME = ORCL)
        )
        )',
        'username' => 'JGI_GIT',
        'password' => 'JGI_GIT',
        'platform_options' => ['quote_identifiers' => false]
    ],
    'service_manager' => [
        'factories' => [
            'Zend\Db\Adapter\Adapter' => 'Zend\Db\Adapter\AdapterServiceFactory',
        ],
    ],
];
