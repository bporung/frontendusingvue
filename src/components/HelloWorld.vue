<template>
  <div class="row text-start  my-2">
      <div class="col-11 col-sm-8 col-md-6 col-lg-4 row mx-auto border border-dark">
          <!-- Base -->
          <div class="col-12 row p-2 border-bottom border-dark">
              <div class="col-12">
                <label class="fst-italic">USD - United States Dollars</label>
              </div>
              <div class="col-12 row align-items-center">
                <div class="col">
                  <label>USD</label>
                </div>
                <div class="col">
                  <input type="number" step="0.01" class="form-control shadow-none" placeholder="Enter Amount" v-model="inputUSDAmount">
                </div>
              </div>
          </div>
          <!-- Base -->

          <div class="col-12 row">
            <!-- ITEM -->
            <div class="col-11 row my-3 p-0 mx-auto border border-dark" 
              v-for="(selCurrency , index) in listOfSelectedCurrency" v-bind:key="selCurrency.currency_code">

              <div class="col-10 row px-2 border-end border-dark">
                  <div class="col">
                    <label>{{selCurrency.currency_code}}</label>
                  </div>
                  <div class="col text-end">
                    <span>{{selCurrency.amount}}</span>
                  </div>
                  <div class="col-12">
                    <label class="fst-italic">{{selCurrency.currency_code+' - '+selCurrency.currency_name}}</label>
                  </div>
                  <div class="col-12">
                    <p class="fst-italic p-0 m-0">{{'1 USD = '+selCurrency.currency_code+' '+selCurrency.rates}}</p>
                  </div>
              </div>

              <div class="col-2 row align-items-center text-center">
                <button class="border-0 bg-transparent" v-on:click="deleteSelectedCurrency(index)">-</button>
              </div>

            </div>
            <!-- ITEM -->
            <div class="col-11 row align-items-center my-3 mx-auto border border-dark">

              <!-- Currency mode is OFF/FALSE -->
              <div class="col row align-items-center" v-if="!addCurrencyMode"><button class="border-0 bg-transparent" v-on:click="addCurrencyMode = true">(+) Add More Currencies</button></div>
              
              <!-- Currency mode is ON/TRUE -->
              <div class="col row align-items-center p-0 m-0" v-else>
                <div class="col row p-0 m-0 border-end border-dark">
                  <select class="form-control border-0 shadow-none" v-model="inputCurrency"  ref="selection">
                    <option value="">Select Currency</option>
                    <option v-for="currency in notSelectedCurrencies" v-bind:key="currency.currency_code" :value="currency.currency_code">{{currency.currency_code}}</option>
                  </select>
                </div>
                <div class="col-2 row m-0 p-0"><button class="border-0 bg-transparent" v-on:click="submitNewCurrency"> Submit</button></div>
              </div>

            </div>
          </div>

      </div>
  </div>
</template>

<script>
import _ from 'lodash'
import axios from 'axios'
import numeral from 'numeral'
export default {
  name: 'HelloWorld',
  
  data: function () {
     return {
       inputUSDAmount : 10.00,
       inputCurrency: '',
        
       listOfSelectedCurrency: [],
       results: {},

       addCurrencyMode: false,

       currencies: [
         {'currency_code' : 'IDR','currency_name' : 'Indonesian Rupiah','selected' : true,'rates' : 0,'amount' : 0},
         {'currency_code' : 'CAD','currency_name' : 'Canadian Dollar','selected' : true,'rates' : 0,'amount' : 0},
         {'currency_code' : 'GBP','currency_name' : 'British Pound','selected' : true,'rates' : 0,'amount' : 0},
         {'currency_code' : 'CHF','currency_name' : 'Swiss Franc','selected' : false,'rates' : 0,'amount' : 0},
         {'currency_code' : 'SGD','currency_name' : 'Singapore Dollar','selected' : false,'rates' : 0,'amount' : 0},
         {'currency_code' : 'INR','currency_name' : 'Indian Rupee','selected' : false,'rates' : 0,'amount' : 0},
         {'currency_code' : 'MYR','currency_name' : 'Malaysian Ringgit','selected' : false,'rates' : 0,'amount' : 0},
         {'currency_code' : 'JPY','currency_name' : 'Japanese Yen','selected' : false,'rates' : 0,'amount' : 0},
         {'currency_code' : 'KRW','currency_name' : 'South Korean Won','selected' : false,'rates' : 0,'amount' : 0},
       ],

     }
  },
  created: function(){
    this.preparationDatas()
  },
  watch:{
    inputUSDAmount: _.debounce(function(){
        this.setupData()
    },1000)
  },
  methods: {
    preparationDatas(){
      // Get Data Once From API
      this.getDatas()

      // Update List Selected Currency base on Status - selected === true from currencies
      this.listOfSelectedCurrency = this.selectedCurrencies
    },
    getDatas(){ 
        axios.get('https://api.exchangerate.host/latest?base=USD')
            .then(response => {
              this.results = response.data.rates
              this.setupData()
            })
            .catch(error => {console.log(error);})
    },
    setupData(index){ 
      var res = this.results
      if(index >= 0){
        // Set Data by Index
          let rates = res[this.listOfSelectedCurrency[index].currency_code]
          this.listOfSelectedCurrency[index].rates = this.setRatesOrAmount('rates',rates)
          this.listOfSelectedCurrency[index].amount = this.setRatesOrAmount('amount',rates)
      }else{
        // Set Array Data
        for(var i = 0; i < this.listOfSelectedCurrency.length; i++){
          let rates = res[this.listOfSelectedCurrency[i].currency_code]
          this.listOfSelectedCurrency[i].rates = this.setRatesOrAmount('rates',rates)
          this.listOfSelectedCurrency[i].amount = this.setRatesOrAmount('amount',rates)
        }
      }
    },
    submitNewCurrency(){
      if(this.inputCurrency){
          this.currencies.find(currency => { if (currency.currency_code === this.inputCurrency) {
              // Update currency status to true
              currency.selected = true
              // Add selected data to List of Selected Currency
              this.listOfSelectedCurrency.push(currency)
          }})
              //Setup New Selected Currency 
              this.setupData(this.listOfSelectedCurrency.length - 1)

              // RESET ADD Currency Mode & Inputed Currency
              this.addCurrencyMode = false
              this.inputCurrency = ''
      }
    },
    deleteSelectedCurrency(index){
        // Update Selected Status to False
        this.currencies.find(currency => { if (currency.currency_code === this.listOfSelectedCurrency[index].currency_code) {currency.selected = false ;}})
        // Delete From List
        this.listOfSelectedCurrency.splice(index,1)
    },
    setRatesOrAmount(type,rates){
      if(type == 'rates'){
        // Set Rates and Using numeral format
        return numeral(rates).format('0,0.0000');
      }
      if(type == 'amount'){
        // Set Amount and Using numeral format
        return numeral(rates * this.inputUSDAmount).format('0,0.0000');
      }
    }
  },
  computed:{
      selectedCurrencies() {
        // Filter only selected === true
        return this.currencies.filter(currency => currency.selected === true)
      },
      notSelectedCurrencies() {
        // Filter only selected === false
        return this.currencies.filter(currency => currency.selected === false)
      },
  }
}
</script>

<style scoped>
  div{margin:0 ; padding: 0;}
</style>
