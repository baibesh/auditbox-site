// A "copy" button on every command block.
for (const block of document.querySelectorAll(".cmd")) {
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = "Скопировать";
  button.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(block.querySelector("code").innerText);
      button.textContent = "Скопировано";
      setTimeout(() => (button.textContent = "Скопировать"), 1800);
    } catch {
      /* no clipboard access: the text can be selected by hand */
    }
  });
  block.appendChild(button);
}
