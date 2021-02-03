<template>
    <tr>
      <td>
         <router-link v-bind:to="'/resource/' + this.resource.id">{{ resource.resource_name }}</router-link>
      </td>
    </tr>
</template>

<script>
export default {
  props: ["resource"]
};
</script>