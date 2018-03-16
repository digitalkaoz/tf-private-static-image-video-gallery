import PropTypes from 'prop-types';
import React, { Component } from 'react';
import Lightbox from 'react-images';
import { Player } from 'video-react';

const theme = {
    arrow__direction__left: { marginLeft: 10 },
    arrow__direction__right: { marginRight: 10 },

    container: {
        background: 'rgba(36,41,67,0.9)',
    },
    close: {
        top: 20,
        position: 'fixed',
        right: 40,
        opacity: 0.6,
        padding: '0 7px 7px 7px',
        fontSize: '100%',
        transition: 'filter .35s ease,-webkit-filter .35s ease,opacity .375s ease-out',
        ':hover': {
            opacity: 1,
        },
    },

    // footer
    footer: {
        color: 'black',
    },
    footerCount: {
        color: 'rgba(0, 0, 0, 0.6)',
    },

    download: {
        top: 20,
        position: 'fixed',
        left: 40,
        opacity: 0.6,
        padding: 7,
        transition: 'all 200ms',
        ':hover': {
            opacity: 1,
        },
    },

    // thumbnails
    thumbnail: {
    },
    thumbnail__active: {
        boxShadow: '0 0 0 2px #FFFFFF',
    },
};

class Gallery extends Component {
    constructor () {
        super();

        this.state = {
            lightboxIsOpen: false,
            currentImage: 0,
        };

        this.closeLightbox = this.closeLightbox.bind(this);
        this.gotoNext = this.gotoNext.bind(this);
        this.gotoPrevious = this.gotoPrevious.bind(this);
        this.gotoImage = this.gotoImage.bind(this);
        this.handleClickImage = this.handleClickImage.bind(this);
        this.openLightbox = this.openLightbox.bind(this);
    }

    openLightbox (index, event) {
        event.preventDefault();
        if (document) {
            document.getElementById('wrapper').style.filter = 'blur(0.5em)';
        }
        this.setState({
            currentImage: index,
            lightboxIsOpen: true,
        });
    }
    closeLightbox () {
        if (document) {
            document.getElementById('wrapper').style.filter = '';
        }
        this.setState({
            currentImage: 0,
            lightboxIsOpen: false,
        });
    }

    gotoPrevious () {
        this.setState({
            currentImage: this.state.currentImage - 1,
        });
    }

    gotoNext () {
        this.setState({
            currentImage: this.state.currentImage + 1,
        });
    }

    gotoImage (index) {
        this.setState({
            currentImage: index,
        });
    }

    handleClickImage () {
        if (this.state.currentImage === this.props.images.length - 1) return;

        this.gotoNext();
    }

    handleDownloadClick() {
        const link = document.createElement('a');
        link.download = this.props.images[this.state.currentImage].src;
        link.href = this.props.images[this.state.currentImage].src;
        link.click();
    }

    render () {
        return (
            <div className="gallery">
            {/*<React.Fragment key={this.props.heading}>*/}
                {this.props.heading && <h2>{this.props.heading}</h2>}
                {this.props.subheading && <p>{this.props.subheading}</p>}

                {this.props.images.map((image, i) =>
                    <div className="gallery--thumbnail" key={image.src}>
                        { image.src.endsWith('.mp4') ?
                            <Player poster={image.src.replace('.mp4', '_00001.png')}><source src={image.src} /></Player> :
                            <a href={image.src} onClick={(e) => this.openLightbox(i, e)} className="image"><img className="gallery--source" src={image.src} alt=""/></a>
                        }
                    </div>
                )}

                <Lightbox
                    backdropClosesModal={true}
                    currentImage={this.state.currentImage}
                    customControls={[<button key="download" onClick={() => this.handleDownloadClick()} className="gallery--download">download</button>]}
                    images={this.props.images.filter((image) => !image.src.endsWith('.mp4'))}
                    isOpen={this.state.lightboxIsOpen}
                    onClickImage={this.handleClickImage}
                    onClickNext={this.gotoNext}
                    onClickPrev={this.gotoPrevious}
                    onClickThumbnail={this.gotoImage}
                    onClose={this.closeLightbox}
                    showThumbnails={this.props.showThumbnails}
                    theme={theme}
                />
            </div>
        );
    }
}

Gallery.displayName = 'Gallery';
Gallery.propTypes = {
    heading: PropTypes.string,
    images: PropTypes.array,
    showThumbnails: PropTypes.bool,
    subheading: PropTypes.string,
};

export default Gallery;