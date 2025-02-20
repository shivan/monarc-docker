<?php
/**
 * Local Configuration Override
 *
 * This configuration override file is for overriding environment-specific and
 * security-sensitive configuration information. Copy this file without the
 * .dist extension at the end and populate values as needed.
 *
 * @NOTE: This file is ignored from Git by default with the .gitignore included
 * in ZendSkeletonApplication. This is a good practice, as it prevents sensitive
 * credentials from accidentally being committed into version control.
 */

$appdir = getenv('APP_DIR') ?: '/var/lib/monarc';

$package_json = json_decode(file_get_contents('./package.json'), true);

return [
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => [
                    'host' => getenv('DB_HOST'),
                    'user' => getenv('DB_USER'),
                    'password' => getenv('DB_PASSWORD'),
                    'dbname' => 'monarc_common',
                ],
            ],
            'orm_cli' => [
                'params' => [
                    'host' => getenv('DB_HOST'),
                    'user' => getenv('DB_USER'),
                    'password' => getenv('DB_PASSWORD'),
                    'dbname' => 'monarc_cli',
                ],
            ],
        ],
    ],

    'languages' => [
        'fr' => [
            'index' => 1,
            'label' => 'Français',
        ],
        'en' => [
            'index' => 2,
            'label' => 'English',
        ],
        'de' => [
            'index' => 3,
            'label' => 'Deutsch',
        ],
        'nl' => [
            'index' => 4,
            'label' => 'Nederlands',
        ],
        'es' => [
            'index' => 5,
            'label' => 'Spanish',
        ],
        'ro' => [
            'index' => 6,
            'label' => 'Romanian',
        ],
        'it' => [
            'index' => 7,
            'label' => 'Italian',
        ],
        'pt' => [
            'index' => 9,
            'label' => 'Portuguese',
        ],
        'pl' => [
            'index' => 10,
            'label' => 'Polish',
        ],
        'jp' => [
            'index' => 11,
            'label' => 'Japanese',
        ],
        'zh' => [
            'index' => 12,
            'label' => 'Chinese',
        ],
    ],

    'defaultLanguageIndex' => 1,

    'activeLanguages' => array('fr','en','de','nl','es','ro','it','ja','pl','pt','zh'),

    'appVersion' => $package_json['version'],

    'checkVersion' => true,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'email' => [
        'name' => 'MONARC',
        'from' => 'info@monarc.lu',
    ],

    'instanceName' => 'Development', // for example a short URL or client name from ansible
    'twoFactorAuthEnforced' => false,

    'terms' => 'https://my.monarc.lu/terms.html',

    'monarc' => [
        'ttl' => 60,
        'cliModel' => 'generic',
    ],

    'twoFactorAuthEnforced' => false,

    'mospApiUrl' => 'https://objects.monarc.lu/api/',

    'statsApi' => [
        'baseUrl' => 'http://127.0.0.1:5005',
        'apiKey' => '',
    ],

    'import' => [
        'uploadFolder' => $appdir . '/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
