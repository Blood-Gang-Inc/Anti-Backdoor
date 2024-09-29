// Smooth scrolling for internal links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// Dynamically update the footer with the current year
document.addEventListener("DOMContentLoaded", function() {
    const footerYear = new Date().getFullYear();
    const footerText = document.querySelector('footer p');
    if (footerText) {
        footerText.innerHTML = `&copy; ${footerYear} Blood Gang™️, Inc`;
    }
});

// Alert and confirm external links (any link that is not to GitHub)
document.querySelectorAll('a').forEach(link => {
    const isExternal = link.href && !link.href.includes('github.com');
    
    if (isExternal) {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const userConfirmed = confirm('You are about to visit an external site. Do you wish to proceed?');
            if (userConfirmed) {
                window.open(link.href, '_blank');
            }
        });
    }
});
