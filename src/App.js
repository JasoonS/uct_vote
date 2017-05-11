import React, { Component } from 'react'
import SimpleStorageContract from '../build/contracts/SimpleStorage.json'
import Web3 from 'web3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'


import InvestecCoin from '../build/contracts/InvestecCoin.json'

const provider = window.web3.currentProvider
// const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const contract = require('truffle-contract')
const iCoin = contract(InvestecCoin)
iCoin.setProvider(provider)

// // Get Web3 so we can get our accounts.
const web3 = new Web3(provider)

let bank = "0x3b26935917de7f5fac60f6d15ff02b1cf468dfb0"
let user = "0xc430e396b63d40fee619c8e3828f68cf00756ece"
let thirdP = "0xcf8393b82491510f48cae6e9fb2e7bdf7390f801"
// Get accounts.
// web3.eth.getAccounts(function(error, accounts) {
//   console.log(accounts)
  let ic
  iCoin.deployed().then(function(iC) {
    ic = iC
    // 1
  //   return ic.mint(user, 123, {from: bank})
  // })
  // .then((res) => {
  //   return ic.balanceOf(user)
  // })

  // 2
  //   return ic.redeemCoins(100, {from: user})
  // })
  // .then((res) => {
  //   return ic.balanceOf(user)
  // }).then((res) => {
  //   console.log(res)
  // })

  // 3
    // ic.requestPayment(user, 20, "payment, yess", {from: thirdP})
    // })


 // 4
  //   ic.viewPayRequests({from: user}).then(function(result) {
  //     console.log(
  //       {
  //         firstNames: result[0].map(i => window.web3.toAscii(i)),
  //         lastNames: result[1].map(i => i),
  //         ages: String(result[2]).split(',') // this is a bit of a hack to get an array of int strings from bigints
  //       }
  //     )
  //   })
  // })

  // 5
  // ic.makeReqPayment()
  // }).then((res) => {
  //   return ic.balanceOf(user)
  // }).then((res) => {
  //   console.log(res)
  // })


  // 6
    return ic.balanceOf(thirdP)
  }).then((res) => {
    console.log(res)
  })

  // 7 - bank redeems

class App extends Component {
  constructor(props) {
    super(props)

    this.setInputValue = this.setInputValue.bind(this)
    this.setValueOnChain = this.setValueOnChain.bind(this)
    this.getValueFromBC = this.getValueFromBC.bind(this)

    this.state = {
      storageValue: 0,
      inputValue: 0
    }
  }
  // This causes a bug, something about updating during rendering...
  // componentDidMount() {
  //   this.getValueFromBC()
  // }

  setValueOnChain() {
    let self = this
    const provider = window.web3.currentProvider
    // const provider = new Web3.providers.HttpProvider('http://localhost:8545')
    const contract = require('truffle-contract')
    const simpleStorage = contract(SimpleStorageContract)
    simpleStorage.setProvider(provider)
    const web3RPC = new Web3(provider)

    let simpleStorageInstance

    web3RPC.eth.getAccounts(function(error, accounts) {
      simpleStorage.deployed().then(function(instance) {
        simpleStorageInstance = instance
        return simpleStorageInstance.set(self.state.inputValue, {from: accounts[0]})
      }).then(function(result) {
        // Get the value from the contract to prove it worked.
        return simpleStorageInstance.get.call(accounts[0])
      }).then(function(result) {
        // Update state with the result.
        return self.setState({ storageValue: result.c[0] })
      })
    })
  }

  getValueFromBC() {
    let self = this
    const provider = window.web3.currentProvider
    // const provider = new Web3.providers.HttpProvider('http://localhost:8545')
    const contract = require('truffle-contract')
    const simpleStorage = contract(SimpleStorageContract)
    simpleStorage.setProvider(provider)
    const web3RPC = new Web3(provider)

    simpleStorage.deployed().then(function(instance) {
      instance.get().then(function(result) {
        self.setState(
          {
            ...self.state,
            storageValue: result,
          }
        )
      })
    })
  }

  setInputValue(e) {
    this.setState({
      ...this.state,
      inputValue: e.target.value
    })
  }

  render() {
    return (
      <div className="App">
      <h1>0x3b26935917de7f5fac60f6d15ff02b1cf468dfb0</h1>
        <h1>0xc430e396b63d40fee619c8e3828f68cf00756ece</h1>
        <h1>0xcf8393b82491510f48cae6e9fb2e7bdf7390f801</h1>
        <p>The box (below) value is: {this.state.inputValue}</p>
        <p>The stored (in the ethereum blockchain) value is: {this.state.storageValue}</p>
        <input value={this.state.inputValue} type="number" onChange={this.setInputValue}/>
        <button onClick={this.setValueOnChain}>Set in Blockchain</button>
      </div>
    )
  }
}

export default App
