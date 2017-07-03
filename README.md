teracycle-pool
====================
##### Teracycle-pool is a linux-based cryptonote currency mining pool, currently configured for Monero (XMR). API and frontend are NodeJS, with Redis as the database.

### Usage

You will need a fresh Ubuntu Server 16 x64 install, preferably with a domain pointed at it.

#### Ideal Hardware Specs
Technically you could run this pool on very little hardware, or a budget VPS, but if you're expecting to be able to handle enough users to make it profitable, you'll need something resembling the following:

* CPU: 4 cores
* RAM: 8GB
* HD: 60GB SSD
* Net: 200mMbit/s
* OS: Ubuntu 16.x



#### Thanks
This project was originally forked from the work of zone117x, fancoder, gingeropolous, snipa22, mesh0000 and clintar.

#### Install

You can use the install script to set up the api, database and frontend automatically, or you can open the script and run through the code step by step.

```bash
curl -sL https://raw.githubusercontent.com/Teracycle/teracycle-pool/master/setup/install.sh | bash
```

#### Configuration


[**Redis security warning**](http://redis.io/topics/security): be sure firewall access to redis - an easy way is to
include `bind 127.0.0.1` in your `redis.conf` file. Also it's a good idea to learn about and understand software that
you are using - a good place to start with redis is [data persistence](http://redis.io/topics/persistence).


*Here is a brief description of most fields:*
```javascript
{
    "coin": "monero", // name of the currency, affects the header branding.
    "symbol": "XMR", // abbreviated currency name, trade symbol

    "logging": {
        "files": {
            "level": "info", // verbosity
            "directory": "logs", // save location
            "flushInterval": 5 // flushing logs lol
        },
        "console": {
            "level": "info", // amount of verbosity in the terminal
            "colors": true // colorized output
        }
    },

    "poolServer": {
        "enabled": true, // api on or off
        "clusterForks": "auto",
        "poolAddress": // pool's wallet address "44M3UPnJmcz2Zx6YLKeeTjV44LgPguD7pfmuwaw92T5f7cgfHfBMBRMethrxjUbn4kdsBMNXPWHhd7bXZUmL2DtN99AB8KX",
        "blockRefreshInterval": 1000,
        "minerTimeout": 900,
        "ports": [ // these are the ports you'll offer your miners
            {
                "port": 3333, // miners specify this port
                "difficulty": 100, // starting difficulty
                "desc": "Low end hardware" // description
            },
            {
                "port": 5555, // miners specify this port
                "difficulty": 2000, // starting difficulty
                "desc": "Mid range hardware" // description
            },
            {
                "port": 7777, // miners specify this port
                "difficulty": 10000, // starting difficulty
                "desc": "High end hardware" // description
            },
            {
                "port": 8888, // not sure why you'd want a hidden port, but here it is.
                "difficulty": 10000, // starting difficulty
                "desc": "Hidden port", // description
                "hidden": true
            }
        ],
        "varDiff": {
            "minDiff": 2,
            "maxDiff": 100000,
            "targetTime": 100,
            "retargetTime": 30,
            "variancePercent": 30,
            "maxJump": 100
        },
        "shareTrust": {
            "enabled": true,
            "min": 10,
            "stepDown": 3,
            "threshold": 10,
            "penalty": 30
        },
        "banning": {
            "enabled": true,
            "time": 600,
            "invalidPercent": 25,
            "checkThreshold": 30
        },
        "slushMining": { // I'm not sure if this works
            "enabled": false,
            "weight": 300,
            "blockTime": 60,
            "lastBlockCheckRate": 1
        }
    },

    "payments": {
        "enabled": true, // payday timer on or off
        "interval": 600, // how often to pay miners who earned a payout 600 = 10mins
        "maxAddresses": 50, // how many at a time
        "mixin": 3, // 3 is the minimum
        "transferFee": 5000000000, // mind the decimals. .005 i think?
        "minPayment": 1000000000000, // 1XMR minimum for payout to reduce fees
        "denomination": 100000000000
    },

    "blockUnlocker": { // this guy signs the paychecks
        "enabled": true,
        "interval": 30,
        "depth": 60,
        "poolFee": 1,
        "devDonation": 0,
        "coreDevDonation": 0
    },

    "api": { // this handles your stats
        "enabled": true,
        "hashrateWindow": 600,
        "updateInterval": 5,
        "port": 8117,
        "blocks": 30,
        "payments": 30,
        "password": "Password898989" // admin page was removed. this is not needed currently
    },

    "daemon": { // port for monero-daemon
        "host": "127.0.0.1",
        "port": 18081
    },

    "wallet": { // port for monero-wallet-rpc
        "host": "127.0.0.1",
        "port": 8082
    },

    "redis": { // port for database
        "host": "127.0.0.1",
        "port": 6379,
        "auth": null
    }
}
```
The file `config.json` is used by default but a file can be specified using the `-config=file` command argument, for example:

```bash
forever init.js -config=config_backup.json
```

This software contains four distinct modules:
* `pool` - Which opens ports for miners to connect and processes shares
* `api` - Used by the website to display network, pool and miners' data
* `unlocker` - Processes block candidates and increases miners' balances when blocks are unlocked
* `payments` - Sends out payments to miners according to their balances stored in redis


By default, running the `init.js` script will start up all four modules. You can optionally have the script start
only start a specific module by using the `-module=name` command argument, for example:

```bash
forever init.js -module=pool
forever init.js -module=api
forever init.js -module=unlocker
forever init.js -module=payments
```

Edit the variables in the `website_example/config.js` file to use your pool's specific configuration.
Variable explanations:

```javascript

/* Must point to the API setup in your config.json file. */
var api = "http://teracycle.net:8117";

/* Minimum units in a single coin, for Bytecoin its 100000000. */
var coinUnits = 1000000000000;

/* Pool server host to instruct your miners to point to.  */
var poolHost = "teracycle.net";

/* IRC Server and room used for embedded KiwiIRC chat. */
var irc = "irc.freenode.net/#monero";

/* Contact email address. */
var email = "support@email.com";

/* Market stat display params from https://www.cryptonator.com/widget */
var cryptonatorWidget = ["XMR-BTC", "XMR-USD", "XMR-EUR", "XMR-GBP"];

/* Download link to cryptonote-easy-miner for Windows users. */
var easyminerDownload = "https://github.com/zone117x/cryptonote-easy-miner/releases/";

/* Used for front-end block links. For other coins it can be changed, for example with
   Bytecoin you can use "https://minergate.com/blockchain/bcn/block/". */
var blockchainExplorer = "http://monerochain.info/block/";

/* Used by front-end transaction links. Change for other coins. */
var transactionExplorer = "http://monerochain.info/tx/";

```


#### Upgrading
When updating to the latest code its important to not only `git pull` the latest from this repo, but to also update
the Node.js modules, and any config files that may have been changed.
* Inside your pool directory (where the init.js script is) do `git pull` to get the latest code.
* Remove the dependencies by deleting the `node_modules` directory with `rm -r node_modules`.
* Run `npm update` to force updating/reinstalling of the dependencies.
* Compare your `config.json` to the latest example ones in this repo or the ones in the setup instructions where each config field is explained. You may need to modify or add any new changes.

### JSON-RPC Commands from CLI

Documentation for JSON-RPC commands can be found here:
* Daemon https://wiki.bytecoin.org/wiki/Daemon_JSON_RPC_API
* Wallet https://wiki.bytecoin.org/wiki/Wallet_JSON_RPC_API


Curl can be used to use the JSON-RPC commands from command-line. Here is an example of calling `getblockheaderbyheight` for block 100:

```bash
curl 127.0.0.1:18081/json_rpc -d '{"method":"getblockheaderbyheight","params":{"height":100}}'
```

#### Feature Roadmap
**This progress is tracked via Trello publicly at:
https://trello.com/b/PsqX8itf/teracycle-pool**

- **[done]** automatic install script for ubuntu 16.x
- **[WIP]** slack notification via webhook for blocks broken
- **[WIP]** day/night easy theme switcher
- **[ ]** currency toggle for other cryptonotes

* TCP (stratum-like) protocol for server-push based jobs
  * Compared to old HTTP protocol, this has a higher hash rate, lower network/CPU server load, lower orphan
    block percent, and less error prone
* IP banning to prevent low-diff share attacks
* Socket flooding detection
* Payment processing
  * Splintered transactions to deal with max transaction size
  * Minimum payment threshold before balance will be paid out
  * Minimum denomination for truncating payment amount precision to reduce size/complexity of block transactions
* Detailed logging
* Ability to configure multiple ports - each with their own difficulty
* Variable difficulty / share limiter
* Share trust algorithm to reduce share validation hashing CPU load
* Clustering for vertical scaling
* Modular components for horizontal scaling (pool server, database, stats/API, payment processing, front-end)
* Live stats API (using AJAX long polling with CORS)
  * Currency network/block difficulty
  * Current block height
  * Network hashrate
  * Pool hashrate
  * Each miners' individual stats (hashrate, shares submitted, pending balance, total paid, etc)
  * Blocks found (pending, confirmed, and orphaned)
* An easily extendable, responsive, light-weight front-end using API to display data
* Worker login validation (make sure miners are using proper wallet addresses for mining)


### Community / Support

* [Monero Github](https://github.com/monero-project/bitmonero)
* [Monero Announcement Thread](https://bitcointalk.org/index.php?topic=583449.0)
* IRC (freenode)
  * Support / general discussion join #monero: https://webchat.freenode.net/?channels=#monero
  * Development discussion join #monero-dev: https://webchat.freenode.net/?channels=#monero-dev

Donations
---------
* BTC: `19NFjoifjMys1cMmzWVSfZUMQpJm7zURmG`
* XMR: `44bBEdVybk9aSYu9JfVDwjXb1zTrKJy1mCfW8EbiHb916Q9uHdv5UvfBccnLLEWCZfMZrP3VT4uCQFVvxcgoBygq6E5DWBA`


License
-------
Released under the GNU General Public License v2

http://www.gnu.org/licenses/gpl-2.0.html
