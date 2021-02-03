<template>
 <div>
  Getting a random resource...
  <p v-if="state == 'error'" class="orange">{{ error }}</p>
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  created() {
    this.loadResource();
  },
  data() {
    return {
      error: "",
      state: "loading"
    };
  },
  methods: {
   async loadResource() {
    try{
      const resource = await fetch(
        `http://10.152.152.11:3000/rpc/random_resource`,
        {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
      ).then(response => response.json());
      this.$router.replace({ path: '/resource/'+resource });
      return 'True';
    } catch (err) {
        this.error = err;
        this.state = "error";
    }
   }
  }
};
</script>