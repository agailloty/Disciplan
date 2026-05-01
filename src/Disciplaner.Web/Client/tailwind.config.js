/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './wwwroot/index.html',
        './**/*.razor',
        './**/*.cs',
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Helvetica', 'Arial', 'sans-serif']
            }
        }
    },
    plugins: [],
}
