export const RulesDownload = ({ name }) => {
  const href = '/' + name

  async function save(event) {
    if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return
    event.preventDefault()
    try {
      const response = await fetch(href, { credentials: 'omit', signal: AbortSignal.timeout(10000) })
      if (!response.ok || !/^text\/(plain|markdown)\b/i.test(response.headers.get('content-type') || '')) {
        throw new Error('Expected the raw Markdown file')
      }
      // Browsers honour the requested filename for a local blob after the HTTP redirect.
      const url = URL.createObjectURL(await response.blob())
      const link = document.createElement('a')
      link.href = url
      link.download = name
      document.body.appendChild(link)
      link.click()
      link.remove()
      setTimeout(() => URL.revokeObjectURL(url), 30000)
    } catch {
      window.location.assign(href)
    }
  }

  return <a href={href} download={name} onClick={save}>Download {name}</a>
}
