let labelCount = 0;

function addLabel() {
  const container = document.getElementById("labels-container");
  const labelDiv = document.createElement("div");
  labelDiv.className = "label-group";
  labelDiv.dataset.labelIndex = labelCount;

  for (let i = 0; i < 4; i++) {
    const input = document.createElement("input");
    input.type = "text";
    input.placeholder = `Label ${labelCount + 1} - Line ${i + 1}`;
    input.name = `label${labelCount}-line${i}`;
    input.className = "input-line";
    labelDiv.appendChild(input);
  }

  container.appendChild(labelDiv);
  labelCount++;
}

// Reload the page after clicking the "Reset" button
function reloadLocation() {
  location.reload();
}

document.addEventListener("DOMContentLoaded", () => {
  addLabel();

  document.getElementById("label-form").addEventListener("submit", async function (e) {
    e.preventDefault();
    const data = [];

    for (let i = 0; i < labelCount; i++) {
      const lines = [];
      for (let j = 0; j < 4; j++) {
        const input = document.querySelector(`input[name="label${i}-line${j}"]`);
        if (input) {
          lines.push(input.value/*.trim()*/);
        }
      }
      if (lines.length > 0) {
        data.push(lines);
      }
    }

    const response = await fetch('/print', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ labels: data })
    });

    const result = await response.text();
    alert(result);
  });
});

// Get input from power button
document.getElementById("power-button").addEventListener("click", () => {
  if (confirm("Are you sure you want to shut down the Raspberry Pi?")) {
    fetch("/shutdown", { method: "POST" })
      .then(res => {
        if (res.ok) {
          alert("Shutting down the system...");
        } else {
          alert("Failed to shut down.");
        }
      });
  }
});
