const fs = require('fs/promises')
const path = require('path')
const Handlebars = require('handlebars')
// const routers = require('./routers')


const params = {
    nodeVersions: [
        {nodeVer: '18.5.0', alpineVer: '3.16'},
        {nodeVer: '18.5.0', alpineVer: '3.15'},
        {nodeVer: '16.16.0', alpineVer: '3.16'},
        {nodeVer: '16.16.0', alpineVer: '3.15'},
        {nodeVer: '16.14.0', alpineVer: '3.14'}, // TODO deprecated
        {nodeVer: '14.20.0', alpineVer: '3.16'},
        {nodeVer: '14.20.0', alpineVer: '3.15'},
    ],
    dcmtkVersions: ['3.6.4', '3.6.6', '3.6.7']
}

const removeCommentedCode = (str) => str.split(/\r?\n/).filter(ele => !ele.startsWith('<!--')).join('\r\n')

const main = async () => {
    try {
        // await fs.rm(path.resolve(__dirname, `../cf-files`), {recursive: true, force: true})
        await fs.mkdir(path.resolve(__dirname, `../.github/workflows`))
    } catch (e) {
        if (!e.message.includes('file already exists, mkdir')) {
            throw e
        }
    }

    const workflowTemplateString = removeCommentedCode(await fs.readFile(path.resolve(__dirname, 'workflow.template'), 'utf8'))
    const workflowTemplate = Handlebars.compile(workflowTemplateString)

    const jobTemplateString = removeCommentedCode(await fs.readFile(path.resolve(__dirname, 'job.template'), 'utf8'))
    const jobTemplate = Handlebars.compile(jobTemplateString)

    const jobs = []
    params.dcmtkVersions.forEach(dcmtkVer => {
        params.nodeVersions.forEach(({nodeVer, alpineVer}) => {
            const build = `build_dcmtk${dcmtkVer}_nodejs${nodeVer}_alpine${alpineVer}`.replace(/\./g, '_')
            const config = {build, dcmtkVer, nodeVer, alpineVer}
            jobs.push(jobTemplate(config))
        })
    })

    const workflowYml = workflowTemplate({jobs: jobs.join('\n\n')})
        .replace(/\[\[/g, '{{')
        .replace(/]]/g, '}}')
        .replace(/&quot;/g, '"')

    await fs.writeFile(path.resolve(__dirname, `../.github/workflows/dockerimage.yml`), workflowYml)
}

main().catch(e => {
    throw e
})


