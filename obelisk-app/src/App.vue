<template>
  <router-link to="/" style="nav">Home</router-link>
  <div v-if="jwt.name" class="login">
    Signed in as {{ jwt.name }}
    <button v-on:click="sign_out">Sign Out</button>
  </div>
  <router-link v-else to="/login" class="login">Sign In</router-link>
  <div v-if="jwt.name" class="sidebar">
      <a>Resources saved for insertion into fields:</a>
      <div v-for="s_resource in saved_resources" :key="s_resource.id">
        <!-- Doing two seperate tags here because it wasn't changing properly. -->
        <saved v-if="this.button_action == 'Remove'" v-bind:sidebar_action="'Remove'" 
          :resource="s_resource" v-on:click-sidebar="action"/>
        <saved v-if="this.button_action == 'Select'" v-bind:sidebar_action="'Select'" 
          :resource="s_resource" v-on:click-sidebar="action"/>
      </div>
  </div>
  <router-view 
    @click-add="add" @click-insert="ready_insertion" @click-uninsert="reset_sb"
    @login="sign_in" @logout="sign_out" v-bind:user_jwt="jwt"
    v-bind:prod_resource="insert_resource" class="main"/>
</template>

<style>

.login {
  margin-right: 30px;
  text-align: right;
  float: right;
}

.sidebar {
  height: 100%; /* Full-height: remove this if you want "auto" height */
  width: 220px; /* Set the width of the sidebar */
  position: fixed; /* Fixed Sidebar (stay in place on scroll) */
  z-index: 1; /* Stay on top */
  top: 0; /* Stay at the top */
  left: 0;
  background-color: #ADD8E6;
  overflow-x: hidden;
  padding-top: 20px;
}

.main {
  margin-left: 220px; /* Same as the width of the sidebar */
  padding: 0px 10px;
  float: center;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>

<script>
import Saved_res from "@/components/Saved_res.vue";

export default {
  data() {
    return {
      saved_resources: {},
      button_action: 'Remove',
      insert_resource: {},
      reload_key: 0,
      jwt: {name:'', jwt:'', editor:false}
    };
  },
  components: {
    'saved': Saved_res
  },
  methods: {
    action(res_id) {
      if (this.button_action == 'Remove') {
        delete this.saved_resources[res_id];
      } else if (this.button_action == 'Select') {
        this.insert_resource = this.saved_resources[res_id];
        //console.log(this.insert_resource);
      }
    },
    add(add_resource) {
      this.saved_resources.[add_resource.id] = Object.assign({}, add_resource);
      delete this.saved_resources.[add_resource.id].productions;
      delete this.saved_resources.[add_resource.id].starting_productions;
      delete this.saved_resources.[add_resource.id].token;
      console.log(this.saved_resources.[add_resource.id]);
    },
    ready_insertion() {
      this.button_action='Select';
    },
    reset_sb() {
      this.button_action = 'Remove';
      this.insert_resource = {};
    },
    sign_in(new_jwt) {
      console.log(new_jwt);
      this.jwt = new_jwt;
    },
    sign_out() {
      this.jwt = {name:'', jwt:'', editor:false};
    }
  }
};
</script>