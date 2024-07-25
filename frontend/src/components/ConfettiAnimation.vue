<template>
  <canvas ref="canvas" class="pointer-events-none fixed left-0 top-0 h-full w-full"></canvas>
</template>

<script lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

type Confetti = ReturnType<typeof confetti>

let el: HTMLCanvasElement,
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  mp = 150, //max particles
  particles: Confetti[] = [],
  angle = 0,
  active = true,
  complete = true,
  reactivationTimerId: number,
  stopTimerId: number,
  animationTimerId: number

const colors = {
  options: ['DodgerBlue', 'OliveDrab', 'Gold', 'pink', 'SlateBlue', 'lightblue', 'Violet', 'PaleGreen', 'SteelBlue', 'SandyBrown', 'Chocolate', 'Crimson'],
  id: 0,
  incrementer: 0,
  getColor: function () {
    if (this.incrementer >= 10) {
      this.incrementer = 0
      this.id++
      if (this.id >= this.options.length) {
        this.id = 0
      }
    }
    this.incrementer++
    return this.options[this.id]
  },
}

const confetti = (color: string) => {
  return {
    x: Math.random() * width, // x-coordinate
    y: Math.random() * height - height, //y-coordinate
    r: Math.floor(Math.random() * (30 - 10 + 1) + 10), // random radius from 10 to 30;
    d: Math.random() * mp + 10, //density;
    color: color,
    tilt: Math.floor(Math.random() * 10) - 10,
    tiltAngleIncremental: Math.random() * 0.07 + 0.05,
    tiltAngle: 0,
    draw: function () {
      ctx.beginPath()
      ctx.lineWidth = this.r / 2
      ctx.strokeStyle = this.color
      ctx.moveTo(this.x + this.tilt + this.r / 4, this.y)
      ctx.lineTo(this.x + this.tilt, this.y + this.tilt + this.r / 4)
      return ctx.stroke()
    },
  }
}

const initialize = (canvasValue: HTMLCanvasElement) => {
  el = canvasValue
  ctx = el.getContext('2d')!
  width = window.innerWidth
  height = window.innerHeight
  el.width = width
  el.height = height
  active = true
  complete = false
  particles = []
  complete = false
  for (let i = 0; i < mp; i++) {
    particles.push(confetti(colors.getColor()))
  }
}

const draw = () => {
  ctx.clearRect(0, 0, width, height)
  let results = []
  for (let i = 0; i < mp; i++) {
    results.push(particles[i].draw())
  }
  update()

  return results
}

const update = () => {
  let remainingFlakes = 0
  let particle
  angle += 0.01

  for (let i = 0; i < mp; i++) {
    particle = particles[i]
    if (complete) return

    if (!active && particle.y < -15) {
      particle.y = height + 100
      continue
    }

    stepParticle(particle, i)

    if (particle.y <= height) {
      remainingFlakes++
    }
    checkForReposition(particle, i)
  }

  if (remainingFlakes === 0) {
    complete = true
    if (ctx == undefined) return
    ctx.clearRect(0, 0, width, height)
  }
}

const checkForReposition = (particle: Confetti, index: number) => {
  if ((particle.x > width + 20 || particle.x < -20 || particle.y > height) && active) {
    if (index % 5 > 0 || index % 2 == 0) {
      //66.67% of the flakes
      repositionParticle(particle, Math.random() * width, -10, Math.floor(Math.random() * 10) - 10)
    } else {
      if (Math.sin(angle) > 0) {
        //Enter from the left
        repositionParticle(particle, -5, Math.random() * height, Math.floor(Math.random() * 10) - 10)
      } else {
        //Enter from the right
        repositionParticle(particle, width + 5, Math.random() * height, Math.floor(Math.random() * 10) - 10)
      }
    }
  }
}
const stepParticle = (particle: Confetti, index: number) => {
  particle.tiltAngle += particle.tiltAngleIncremental
  particle.y += (Math.cos(angle + particle.d) + 3 + particle.r / 2) / 2
  particle.x += Math.sin(angle)
  particle.tilt = Math.sin(particle.tiltAngle - index / 3) * 15
}

const repositionParticle = (particle: Confetti, xCoordinate: number, yCoordinate: number, tilt: number) => {
  particle.x = xCoordinate
  particle.y = yCoordinate
  particle.tilt = tilt
}

const start = (duration = 0) => {
  width = window.innerWidth
  height = window.innerHeight
  el.width = width
  el.height = height

  const animloop = () => {
    if (complete) return null
    animationTimerId = window.requestAnimationFrame(animloop)
    return draw()
  }

  animloop()

  if (duration > 0) {
    stopTimerId = setTimeout(stop, duration)
  }
}

const stop = () => {
  active = false
  clearTimeout(reactivationTimerId)
  clearTimeout(animationTimerId)
  clearTimeout(stopTimerId)
}

export { start, stop }
</script>

<script setup lang="ts">
const canvas = ref<HTMLCanvasElement>()

onMounted(() => {
  initialize(canvas.value!)
})

onUnmounted(() => {
  stop()
})
</script>
