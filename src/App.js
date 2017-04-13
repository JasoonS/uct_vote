import React, { Component } from 'react'
import SimpleStorageContract from '../build/contracts/SimpleStorage.json'
import Web3 from 'web3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

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
        <h1>Hello World</h1>
        <p>The box (below) value is: {this.state.inputValue}</p>
        <p>The stored (in the ethereum blockchain) value is: {this.state.storageValue}</p>
        <input value={this.state.inputValue} type="number" onChange={this.setInputValue}/>
        <button onClick={this.setValueOnChain}>Set in Blockchain</button>
      </div>
    )
  }
}

export default App
