<template>
   <a>
    <table style="width: 220px;">
      <td>
         {{ name }}
      </td>
      <td>
         <button v-on:click="click_action">{{ sidebar_action }}</button>
      </td>
    </table>
  </a>
</template>

<script>
export default {
  props: ["resource", "sidebar_action"],
  created() {
    console.log(this.sidebar_action);
  },
  computed: {
    name: function () {
      var output = this.resource.resource_name.substr(0,12);
      console.log(output);
      for (var i=12; i<this.resource.resource_name.length; i+=12) {
        output = output + "-\n" + this.resource.resource_name.substr(i,i+12);
      }
      return output;
    }
  },
  methods: {
    click_action() {
      this.$emit('click-sidebar', this.resource.id);
    }
  }
};
</script>