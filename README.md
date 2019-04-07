# Ethereum Marriage Contract

---
author: Witek Radomski
date: April 7, 2019
source: https://github.com/coinfork/Marriage
---

## Overview
This Smart Contract is meant to be deployed on the Ethereum (1.0) Blockchain.

## Deployment

* To compile and deploy the smart contract, you may use a solidity development environment like https://remix.ethereum.org/
* Paste the contents of the `Marriage.sol` file into Remix, and ensure it's compiled.
* In the Run section, you must enter some initial values for the constructor.
  * _marriageContractId: A human-readable name for this contract.
  * _partner1: The address of the first partner.
  * _partner2: The address of the second partner.
  * _yearsToLockFunds: How many years to lock funds for. Example: 15.
  * _divorceBurnAddress If a divorce occurs, Ether will be sent here. I recommend supplying the public address of a charity that accepts Ether, such as SENS Research Foundation for the betterment of humankind. Their address is: 0x542EFf118023cfF2821b24156a507a513Fe93539
  * _percentToBurnOnDivorce The percentage out of 100 to burn if a divorce happens. Suggested: 90. The remaining funds are sent to the divorce initiator.
* Here is an example of these fields filled out:
  * `"Test Marriage","0xca35b7d915458ef540ade6068dfe2f44e8fa733c","0x14723a09acff6d2a60dcdf7aa4aff308fddc160c",15,"0x542EFf118023cfF2821b24156a507a513Fe93539",90`
* Select the environment to run them in - Javascript VM is for testing, while the Web3 options allow you to deploy to mainnet using an Ethereum wallet like MetaMask in your browser.
* Now the contract will be deployed onto Ethereum. Note down the address in your records by clicking the "Copy" icon beside the Deployed Contract.

## Usage

* You may access the smart contract at any time by using an Ethereum wallet like MyEtherWallet.com
* Visit the website and access your wallet using your Keystore file or Hardware Wallet (recommended)
* In the "Contracts" section, paste your Marriage contract address, and the contents of the `Marriage.abi` file
* You will see a list of functions available.

### Signing your marriage contract

Each party must sign the Marriage contract by executing the `signPartner` function from their wallet.

* Type the name of the partner, for example `"John Smith"`
* Execute `signPartner`
* You may now check `partnerXName` and `partnerXSigned` to see the updated data for each partner.
* When both partners have signed, the lock period becomes active for the number of years in `yearsToLockFunds`

### Updating your address

If you used a temporary wallet during the marriage ceremony, you should update your wallet address using this procedure immediately. You can also update your address at any point in the future in case you change your wallet. I recommend using a hardware wallet (such as a Trezor) or a paper wallet with at least 2 backups.

* Login to your existing wallet
* Call the `updatePartnerAddress` function with your partner number (`1` or `2`) and your new intended wallet address.
* Login to your new wallet
* Call the `acceptUpdatePartnerAddress` function with your partner number (`1` or `2`)
* You can now check `partner1` or `partner2` to see your updated address in the contract!

### Funding the contract

Ether (ETH) may be sent to your contract address at any time, which becomes time-locked savings of your funds until the contract's lock period ends.
Warning: DO NOT send ERC-20 tokens to this contract, as there is no way to retrieve them. Only Ether is supported!

### Life Events

To log significant life events related to your marriage, such as the birth of a child, call addLifeEvent with the description of the event.
You may now look back on your life and marriage with nostalgia by viewing the Ethereum event logs from your contract.

### Guests and Friends of the newly-wed couple

Send your wedding or anniversary wishes by executing `addWishes` with your note for the married couple!

### Divorce

In the unfortunate event of a divorce, one of the partners may call the `divorce` function.

* The majority of funds will be sent to the `divorceBurnAddress` which we suggest to be a charity.
* The rest of the funds will be sent to the person who calls `divorce`.
* For safety, you must enter `1` into the `_confirm` parameter to initiate the divorce. There is no undoing this, please be very careful and reconsider - talk with your partner and save your marriage instead!

### Withdraw Funds

Funds may only be withdrawn if:
* The time lock period is over
* Or both parties haven't signed the marriage contract yet

Simply call the contract from your partner address using `withdrawFunds` and the amount of Ether in wei units. For example, `1000000000000000000` is 1 ETH. The amount of funds you specify will be sent to your account!

Congratulations on your successful marriage! Enjoy your savings! :)
