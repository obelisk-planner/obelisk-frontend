<template>
Reloading...
</template>

<script>

export default {
  created() {
    this.$router.replace({ path: this.$route.path.substr(2) });
  }
};
</script>