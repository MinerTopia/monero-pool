teracycle-pool
====================


#### Features

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

* [CryptoNote Forum](https://forum.cryptonote.org/)
* [Monero Github](https://github.com/monero-project/bitmonero)
* [Monero Announcement Thread](https://bitcointalk.org/index.php?topic=583449.0)
* IRC (freenode)
  * Support / general discussion join #monero: https://webchat.freenode.net/?channels=#monero
  * Development discussion join #monero-dev: https://webchat.freenode.net/?channels=#monero-dev


#### Pools Using This Software

* http://teracycle.net


Usage
===

#### Requirements
You will need a blank Ubuntu Server 16 x64 install on a server, preferably with a domain pointed at it. 

#### Ideal Hardware Specs
Technically you could run this pool on very little hardware, or a budget VPS, but if you're expecting to be able to handle enough users to make it profitable, you'll need something resembling the following:

CPU: 4 cores 
RAM: 8GB
HD: 60GB SSD
Net: 200mMbit/s
OS: Ubuntu 16.x


[**Redis security warning**](http://redis.io/topics/security): be sure firewall access to redis - an easy way is to
include `bind 127.0.0.1` in your `redis.conf` file. Also it's a good idea to learn about and understand software that
you are using - a good place to start with redis is [data persistence](http://redis.io/topics/persistence).


#### Install

You can use the install script to set up everything automatically, or you can open the script and run through the code step by step.
```bash
curl -sL https://raw.githubusercontent.com/Teracycle/teracycle-pool/master/setup/install.sh | bash
```

#### 2) Configuration


*Warning for Cyrptonote coins other than Monero:* this software may or may not work with any given cryptonote coin.
Be wary of altcoins that change the number of minimum coin units because you will have to reconfigure several config
values to account for those changes. Unless you're offering a bounty reward - do not open an issue asking for help
getting a coin other than Monero working with this software.

Explanation for each field:
```javascript

```


The file `config.json` is used by default but a file can be specified using the `-config=file` command argument, for example:

```bash
node init.js -config=config_backup.json
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
var api = "http://poolhost:8117";

/* Minimum units in a single coin, for Bytecoin its 100000000. */
var coinUnits = 1000000000000;

/* Pool server host to instruct your miners to point to.  */
var poolHost = "cryppit.com";

/* IRC Server and room used for embedded KiwiIRC chat. */
var irc = "irc.freenode.net/#monero";

/* Contact email address. */
var email = "support@cryppit.com";

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

Donations
---------
* BTC: `19NFjoifjMys1cMmzWVSfZUMQpJm7zURmG`
* MRO: `44bBEdVybk9aSYu9JfVDwjXb1zTrKJy1mCfW8EbiHb916Q9uHdv5UvfBccnLLEWCZfMZrP3VT4uCQFVvxcgoBygq6E5DWBA`


License
-------
Released under the GNU General Public License v2

http://www.gnu.org/licenses/gpl-2.0.html
