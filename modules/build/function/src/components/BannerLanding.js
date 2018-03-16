import React from 'react'

const BannerLanding = (props) => (
    <section id="banner" style={{
        backgroundImage: `url("${props.image.src}")`
    }}>
        <div className="inner">
            <header className="major">
                <h1>{props.name}</h1>
                <h3>{props.date}</h3>
            </header>
            <div className="content" dangerouslySetInnerHTML={{__html : props.content}}>
            </div>
        </div>
    </section>
)

export default BannerLanding
