import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import test from 'node:test'

function helpSection(audience, heading) {
  const page = readFileSync(new URL('../guides/' + audience + '/account.mdx', import.meta.url), 'utf8')
  const section = page.split(/^## /m).find(part => part.split(/\r?\n/, 1)[0] === heading)
  assert.ok(section, 'Published ' + audience + ' guide needs ' + heading)
  return section
}

test('DOC3A-HELP customer guide covers supported categories, visibility and ticket actions', () => {
  const help = helpSection('business', 'Get help')
  for (const label of ['Settings → Help', 'Support tickets', 'New ticket', 'Subject', 'Message',
    'Problem', 'Billing', 'Raise call limit', 'Report abuse', 'Other', 'Send ticket', 'My tickets',
    'Waiting on customer', 'Send reply', 'Mark solved', 'Reply and reopen', 'Refresh ticket', 'Retry same request']) {
    assert.ok(help.includes('**' + label + '**'), label)
  }
  assert.match(help, /Owners and Admins can see their organisation’s tickets/)
  assert.match(help, /Members can see only the tickets they opened/)
  assert.match(help, /aims to reply within 48 hours, including weekends/)
  assert.doesNotMatch(help, /call[ -]?(?:me[ -]?)?back|staff reply emails?|admin inbox/i)
})

test('DOC3A-DEVELOPER developer guide links the ticket workflow and requests safe diagnostic details', () => {
  const help = helpSection('developer', 'Get help with a request')
  assert.ok(help.includes('Settings → Help → Support tickets'))
  assert.ok(help.includes('request ID or error code'))
  assert.ok(help.includes('Keep credentials and private call content out of the message'))
  assert.ok(help.includes('](/guides/business/account#get-help)'))
  assert.doesNotMatch(help, /call[ -]?(?:me[ -]?)?back|staff reply emails?|admin inbox/i)
})
