<template>
  <table>
    <tr>
      <td> <router-link to="/recipe/random">Random Recipe</router-link> </td>
      <td> <router-link to="/resource/random">Random Resource</router-link> </td>
    </tr><tr>
      <td> <router-link to="/search/recipe">Search Recipes</router-link> </td>
      <td> <router-link to="/search/resource">Search Resources</router-link> </td>
    </tr><tr>
      <td v-if="user_jwt.name"> <router-link to="/form/recipe">New Recipe</router-link> </td>
      <td v-if="user_jwt.name"> <router-link to="/form/resource">New Resource</router-link> </td>
    </tr>
  </table>
</template>

<script>
export default {
  props: ['user_jwt']
}
</script>
