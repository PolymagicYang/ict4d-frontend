<script setup>
defineProps({
  msg: {
    type: String,
    required: true
  }
})
</script>

<template>
  <div class="greetings">
    <h1 class="green">Hertzian-Harmony</h1>
    <h3>
      Curious about the questions? Cast your vote now by simply making a phone call!
    </h3>
    <h4>
      Check results by phone: (800) 289-5570 then PIN: 9996100776 
    </h4>
  </div>
</template>

<style scoped>
h1 {
  font-weight: 400;
  font-size: 2.0rem;
  position: relative;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {
  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}
</style>
