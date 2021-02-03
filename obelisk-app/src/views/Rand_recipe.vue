<template>
 <div>
  Getting a random recipe...
  <p v-if="state == 'error'" class="orange">{{ error }}</p>
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  created() {
    this.loadRecipe();
  },
  data() {
    return {
      error: "",
      state: "loading"
    };
  },
  methods: {
   async loadRecipe() {
    try{
      const recipe = await fetch(
        `http://10.152.152.11:3000/rpc/random_recipe`,
        {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
      ).then(response => response.json());
      this.$router.replace({ path: '/recipe/'+recipe });
      return 'True';
    } catch (err) {
        this.error = err;
        this.state = "error";
    }
   }
  }
};
</script>