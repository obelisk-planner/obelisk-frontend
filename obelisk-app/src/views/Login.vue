<template>
  <p v-if="state == 'error'" class="orange">{{ error }}</p>
  <div v-else-if="state == 'ready'">
    <h1 class="mb4">Login</h1>
    <p>Username: <input v-model="this.username"></p>
    <p>Password: <input type="password" v-model="this.password"></p>
    <p><button v-on:click="login">Sign In</button></p>
  </div>
</template>

<script>

export default {
  data() {
    return {
      username: '',
      password: '',
      state: 'ready',
      error: ''
    };
  },
  methods: {
    async login() {
      try {
        const jwt = await fetch('http://' + process.env.VUE_APP_API_URL + '/rpc/login', {
            method: 'POST',
            body: '{"rol":"'+ JSON.stringify(this.username) 
              +'", "pass":"' + JSON.stringify(this.password) + '"}',
            headers: {'Content-Type': 'application/json;charset=utf-8'}
        }).then(response => response.json());
        const editor = await fetch('http://' + process.env.VUE_APP_API_URL + '/rpc/are_they_editor', {
            method: 'POST',
            body: '{"selected_user":"'+this.username+'"}',
            headers: {'Content-Type': 'application/json;charset=utf-8'}
        }).then(response => response.json());
        if (editor) {
          this.$emit('login', {jwt: jwt[0]['token'], name: this.username, editor: true});
        } else {
          this.$emit('login', {jwt: jwt[0]['token'], name: this.username, editor: false});
        }
        console.log({jwt: jwt[0]['token'], name: this.username});
        if (this.username == 'newuser'){
          this.$router.push({ path: '/newuser'});
        } else {
          this.$router.push({ path: '/'});
        }
      } catch (err) {
          this.error = 'Something went wrong. Most probably, you gave invalid credentials. Reload.';
          //this.error = err;
          this.state = "error";
      }
    }
  }
};
</script>