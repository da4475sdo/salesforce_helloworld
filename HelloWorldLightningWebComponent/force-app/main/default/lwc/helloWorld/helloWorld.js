import { LightningElement } from "lwc";
export default class HelloWorld extends LightningElement {
  greeting = "World11111";
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}
