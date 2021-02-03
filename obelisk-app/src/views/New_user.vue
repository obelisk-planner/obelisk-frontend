<template>
  <p v-if="state == 'error'" class="orange">{{ error }}</p>
  <div v-else-if="state == 'ready'">
    <h1 class="mb4">Create User</h1>
    <p>Username: <input v-model="this.username"></p>
    <p>Password: <input type="password" v-model="this.fpassword"></p>
    <p>Repeat password: <input type="password" v-model="this.spassword"></p>
    <p v-if="!matches">Bad match.</p>
    <p><button v-on:click="create_user">Sign Up</button></p>
  </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  data() {
    return {
      username: '',
      fpassword: '',
      spassword: '',
      state: 'ready',
      error: ''
    };
  },
  computed: {
    matches: function () {
      return this.fpassword == this.spassword;
    }
  },
  methods: {
    async create_user() {
     if (this.matches) {
      try {
        await fetch(`http://10.152.152.11:3000/rpc/add_user`, {
            method: 'POST',
            body: '{"new_user":"'+this.username+'", "new_password":"'+this.fpassword+'"}',
            headers: {
              'Content-Type': 'application/json;charset=utf-8',
              'Authorization': 'Bearer ' + this.user_jwt.jwt
            }
        });
        this.$emit('logout');
        this.$router.push({ path: '/login'});
      } catch (err) {
          this.error = err;
          this.state = "error";
      }
     }
    }
  }
};
</script>