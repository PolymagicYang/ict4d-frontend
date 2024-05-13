import axios from 'axios'
import VueAxios from 'vue-axios'

export let axiosInstance = axios.create({
  baseURL: "https://ict4d-yanghoo-012870880e2d.herokuapp.com/",
  timeout: 3000,
})

export let VueAxiosPlugin = VueAxios